/*
  Copyright (c) 2008, Adobe Systems Incorporated
  All rights reserved.

  Redistribution and use in source and binary forms, with or without 
  modification, are permitted provided that the following conditions are
  met:

  * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
  
  * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the 
    documentation and/or other materials provided with the distribution.
  
  * Neither the name of Adobe Systems Incorporated nor the names of its 
    contributors may be used to endorse or promote products derived from 
    this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
  IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package com.adobe.serialization.lua
{
	
	public class LUADecoder
	{
		
		/**
		 * Flag indicating if the parser should be strict about the format
		 * of the LUA string it is attempting to decode.
		 */
		private var strict:Boolean;
		
		/** The value that will get parsed from the LUA string */
		private var value:*;
		
		/** The tokenizer designated to read the LUA string */
		private var tokenizer:LUATokenizer;
		
		/** The current token from the tokenizer */
		private var token:LUAToken;
		
		
		/**
		 * Constructs a new LUADecoder to parse a LUA string
		 * into a native object.
		 *
		 * @param s The LUA string to be converted
		 *		into a native object
		 * @param strict Flag indicating if the LUA string needs to
		 * 		strictly match the LUA standard or not.
		 * @langversion ActionScript 3.0
		 * @playerversion Flash 9.0
		 * @tiptext
		 */
		public function LUADecoder( s:String, strict:Boolean )
		{
			this.strict = strict;
			tokenizer = new LUATokenizer( s, strict );
			
			nextToken(); //token是第一个"{",ch是第二个"{"
			value = parseValue();
			
			// Make sure the input stream is empty
			if ( strict && nextToken() != null )
			{
				tokenizer.parseError( "Unexpected characters left in input stream" );
			}
		}
		
		/**
		 * Gets the internal object that was created by parsing
		 * the LUA string passed to the constructor.
		 *
		 * @return The internal object representation of the LUA
		 * 		string that was passed to the constructor
		 * @langversion ActionScript 3.0
		 * @playerversion Flash 9.0
		 * @tiptext
		 */
		public function getValue():*
		{
			return value;
		}
		
		/**
		 * Returns the next token from the tokenzier reading
		 * the LUA string
		 */
		private final function nextToken():LUAToken
		{
			return token = tokenizer.getNextToken();
		}
		
		/**
		 * Returns the next token from the tokenizer reading
		 * the LUA string and verifies that the token is valid.
		 */
		private final function nextValidToken():LUAToken
		{
			token = tokenizer.getNextToken();
			checkValidToken();
			
			return token;
		}
		
		/**
		 * Verifies that the token is valid.
		 */
		private final function checkValidToken():void
		{
			// Catch errors when the input stream ends abruptly
			if ( token == null )
			{
				tokenizer.parseError( "Unexpected end of input" );
			}
		}
		
		/**
		 * Attempt to parse an array.
		 */
		private final function parseArray():Array
		{
			// create an array internally that we're going to attempt
			// to parse from the tokenizer
			var a:Array = new Array();
			
			// grab the next token from the tokenizer to move
			// past the opening [
			nextValidToken();
			
			// check to see if we have an empty array
			if ( token.type == LUATokenType.RIGHT_BRACKET )
			{
				// we're done reading the array, so return it
				return a;
			}
			// in non-strict mode an empty array is also a comma
			// followed by a right bracket
			else if ( !strict && token.type == LUATokenType.COMMA )
			{
				// move past the comma
				nextValidToken();
				
				// check to see if we're reached the end of the array
				if ( token.type == LUATokenType.RIGHT_BRACKET )
				{
					return a;
				}
				else
				{
					tokenizer.parseError( "Leading commas are not supported.  Expecting ']' but found " + token.value );
				}
			}
			
			// deal with elements of the array, and use an "infinite"
			// loop because we could have any amount of elements
			while ( true )
			{
				// read in the value and add it to the array
				a.push( parseValue() );
				
				// after the value there should be a ] or a ,
				nextValidToken();
				
				if ( token.type == LUATokenType.RIGHT_BRACKET )
				{
					// we're done reading the array, so return it
					return a;
				}
				else if ( token.type == LUATokenType.COMMA )
				{
					// move past the comma and read another value
					nextToken();
					
					// Allow arrays to have a comma after the last element
					// if the decoder is not in strict mode
					if ( !strict )
					{
						checkValidToken();
						
						// Reached ",]" as the end of the array, so return it
						if ( token.type == LUATokenType.RIGHT_BRACKET )
						{
							return a;
						}
					}
				}
				else
				{
					tokenizer.parseError( "Expecting ] or , but found " + token.value );
				}
			}
			
			return null;
		}
		
		/**
		 * Attempt to parse an object.
		 */
		private final function parseObject():Object
		{
			// create the object internally that we're going to
			// attempt to parse from the tokenizer
			var o:Object = new Object();
			var oIndex:int = 0;
			
			// store the string part of an object member so
			// that we can assign it a value in the object
			var key:String
			
			// grab the next token from the tokenizer
			nextValidToken(); //调这个后的token第二个"{"
			
			// check to see if we have an empty object
			if ( token.type == LUATokenType.RIGHT_BRACE )
			{
				// we're done reading the object, so return it
				return o;
			}
			// in non-strict mode an empty object is also a comma
			// followed by a right bracket
			else if ( !strict && token.type == LUATokenType.COMMA )
			{
				// move past the comma
				nextValidToken();
				
				// check to see if we're reached the end of the object
				if ( token.type == LUATokenType.RIGHT_BRACE )
				{
					return o;
				}
				else
				{
					tokenizer.parseError( "Leading commas are not supported.  Expecting '}' but found " + token.value );
				}
			}
			
			// deal with members of the object, and use an "infinite"
			// loop because we could have any amount of members
			while ( true )
			{
				if ( token.type == LUATokenType.STRING || token.type == LUATokenType.NUMBER)
				{
					// the string value we read is the key for the object
					key = String( token.value );
					
					// move past the string to see what's next
					nextValidToken();
					
					if ( token.type == LUATokenType.RIGHT_BRACKET)
					{
						// 中括号直接找下一个;
						nextValidToken();
					}
					
					// after the string there should be a :
					if ( token.type == LUATokenType.COLON )
					{
						// move past the : and read/assign a value for the key
						nextToken();
						o[ key ] = parseValue();
						oIndex++;
						
						// move past the value to see what's next
						nextValidToken();
						
						// after the value there's either a } or a ,
						if ( token.type == LUATokenType.RIGHT_BRACE )
						{
							// we're done reading the object, so return it
							return o;
						}
						else if ( token.type == LUATokenType.COMMA )
						{
							// skip past the comma and read another member
							nextToken();
							
							// Allow objects to have a comma after the last member
							// if the decoder is not in strict mode
							if ( !strict )
							{
								checkValidToken();
								
								// Reached ",}" as the end of the object, so return it
								if ( token.type == LUATokenType.RIGHT_BRACE )
								{
									return o;
								}
							}
						}
						else
						{
							tokenizer.parseError( "Expecting } or , but found " + token.value );
						}
					}
					else if (token.type == LUATokenType.COMMA)
					{
						o[oIndex] = key;
						oIndex++;
						
						// skip past the comma and read another member
						nextToken();
						
						// Allow objects to have a comma after the last member
						// if the decoder is not in strict mode
						if ( !strict )
						{
							checkValidToken();
							
							// Reached ",}" as the end of the object, so return it
							if ( token.type == LUATokenType.RIGHT_BRACE )
							{
								return o;
							}
						}
					}
					else if (token.type == LUATokenType.RIGHT_BRACE)
					{
						o[oIndex] = key;
						return o;
					}
					else
					{
						tokenizer.parseError( "Expecting : but found " + token.value );
					}
				}
				else
				{
					if (token.type == LUATokenType.RIGHT_BRACE)
					{
						return o;
					}
					else if (token.type == LUATokenType.LEFT_BRACKET)
					{
						// 开始一个key
						nextValidToken();
					}
					else if (token.type == LUATokenType.LEFT_BRACE)
					{	
						o[ oIndex ] = parseObject();
						oIndex++;
						
						// move past the value to see what's next
						nextValidToken();
						
						// after the value there's either a } or a ,
						if ( token.type == LUATokenType.RIGHT_BRACE )
						{
							// we're done reading the object, so return it
							return o;
						}
						else if ( token.type == LUATokenType.COMMA )
						{
							// skip past the comma and read another member
							nextToken();
						}
						else
						{
							tokenizer.parseError( "Expecting } or , but found " + token.value );
						}
					}
				}
			}
			return null;
		}
		
		/**
		 * Attempt to parse a value
		 */
		private final function parseValue():Object
		{
			checkValidToken();
			
			switch ( token.type )
			{
				case LUATokenType.LEFT_BRACE:
					return parseObject();
				
				case LUATokenType.LEFT_BRACKET:
					return parseArray();
				
				case LUATokenType.STRING:
				case LUATokenType.NUMBER:
				//case LUATokenType.TRUE:
				//case LUATokenType.FALSE:
				//case LUATokenType.NULL:
					return token.value;
				
				/*
				case LUATokenType.NAN:
					if ( !strict )
					{
						return token.value;
					}
					else
					{
						tokenizer.parseError( "Unexpected " + token.value );
					}
				*/
				default:
					tokenizer.parseError( "Unexpected " + token.value );
			
			}
			
			return null;
		}
	}
}
