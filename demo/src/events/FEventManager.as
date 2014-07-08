package events
{
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import utils.Logger;
	
	public class FEventManager
	{
		private var _eventMap:Dictionary = null;
		public function FEventManager()
		{
			_eventMap = new Dictionary();
			Logger.info("[FEventManager]Init EventManager");
		}
		
		public function addListener(receiver:*, id:String, callback:Function, repeat:Boolean = true):Boolean
		{
			if (receiver == null) return false;
			if (id == null || id == "")
			{
				Logger.error("[FEventManager.addListener]id is null");
				return false;
			}
			
			if (callback == null)
			{
				Logger.error("[FEventManager.addListener]callback is null");
				return false;
			}			
			var head:FEvent_CallbackInfo = _eventMap[id];
			if (head == null) {
				head = new FEvent_CallbackInfo(); //空的节点
				head.ishead = true;
				_eventMap[id] = head;
			}
			var node:FEvent_CallbackInfo = head.next;
			while (node) {
				if (node.obj == receiver && node.callback == callback)
				{
					Logger.error("[FEventManager.addListener]" + id + " has exist this function");
					return false;
				}
				node = node.next;
			}
			node = new FEvent_CallbackInfo();
			node.callback = callback;
			node.obj = receiver;
			node.repeat = repeat;
			_addNode(head, node);

			return true;
		}
		
		public function dispatch(target:*,id:String, ...param):Boolean
		{
			if (id == null)
			{
				Logger.error("[FEventManager.dispatch]id is null");
				return false;
			}
			
			var head:FEvent_CallbackInfo = _eventMap[id];
			if (head == null) {
				return false;
			}			
			if (target == null) {
				_broadCast(head, param);
			}else {
				_notify(target, head, param);
			}
			return true;
		}
		
		private function _notify(target:*, head:FEvent_CallbackInfo, param:Array):void 
		{
			var node:FEvent_CallbackInfo = head.next;
			var paramCount:int = param.length;
			while (node) {
				if (target == node.obj) {
					if (paramCount == 0)
						node.callback.call(null);
					else
						node.callback.apply(null, param);	
					
					if (!node.repeat)
					{
						node = _removeNode(head, node);
					}
					return;
				}
				else {
					node = node.next;
				}
			}
		}
		
		private function _broadCast(head:FEvent_CallbackInfo, ...param):void
		{
			var node:FEvent_CallbackInfo = head.next;
			var paramCount:int = param.length;
			while (node) {
				if (paramCount == 0)
					node.callback.call(null);
				else
					node.callback.apply(null, param);	
				
				if (!node.repeat)
				{
					node = _removeNode(head, node);
				}else {
					node = node.next;	
				}
			}
		}
		
		private function _addNode(head:FEvent_CallbackInfo, node:FEvent_CallbackInfo):void
		{
			var next:FEvent_CallbackInfo = head.next;
			head.next = node;
			node.prev = head;
			node.next = next;
			if(next) next.prev = node;			
		}
		
		//返回next node
		private function _removeNode(head:FEvent_CallbackInfo, node:FEvent_CallbackInfo):FEvent_CallbackInfo 
		{
			if (node == null || node.ishead) return null;
			var prevNode:FEvent_CallbackInfo = node.prev;
			var nextNode:FEvent_CallbackInfo = node.next;
			prevNode.next = nextNode;
			if (nextNode) nextNode.prev = prevNode;
			node.prev = null;
			node.next = null;
			node.obj = null;
			node.callback = null;
			return nextNode;
		}
		
		public function removeAllListener(receiver:*):void
		{
			if (receiver == null) return;
			for (var id:String in _eventMap)
			{
				removeListener(receiver, id);
			}
		}
		
		public function removeListener(receiver:*, id:String, callback:Function = null):void
		{
			if (receiver == null) return;
			Logger.assert(id != null && id != "", "[FEventManager.removeListener]id is null");
			var head:FEvent_CallbackInfo = _eventMap[id];
			if (head == null){
				return;
			}			
			var node:FEvent_CallbackInfo = head.next;
			while (node) {
				if (node.obj == receiver && (callback == null || callback == node.callback)) {
					node = _removeNode(head, node);
				}else {
					node = node.next;
				}
			}
		}
	}
}

class FEvent_CallbackInfo
{
	public var obj:* = null;
	public var callback:Function = null;
	public var repeat:Boolean = false;
	public var next:FEvent_CallbackInfo = null;
	public var prev:FEvent_CallbackInfo = null;
	public var ishead:Boolean;
}