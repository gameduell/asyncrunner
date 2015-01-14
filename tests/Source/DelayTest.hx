import duell.DuellKit;

import asyncrunner.Async;

typedef TimeTracker = {expectedTime: Float, actualTime: Float};

class DelayTest extends unittest.TestCase
{
    public function test1()
    {
    	var trackers = [];
    	for (i in 0...50)
    	{
    		var delay = Math.random() * 20;
    		var tracker: TimeTracker = {expectedTime: haxe.Timer.stamp() + delay, actualTime: 0.0};
    		trackers.push(tracker);
	        Async.delay(function() {
	        	tracker.actualTime = haxe.Timer.stamp();
			}, delay);
    	}

    	Async.delay(function()
    	{
    		for (tracker in trackers)
    		{
    			trace("diff: " + (tracker.actualTime - tracker.expectedTime));
    		}
    		assertAsyncFinish("test1");
    	}, 25);

        assertAsyncStart("test1", 30);
    }
}
