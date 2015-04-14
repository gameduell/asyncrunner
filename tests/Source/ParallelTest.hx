import duell.DuellKit;

import asyncrunner.Async;

import asyncrunner.Task;

import asyncrunner.ParallelTaskGroup;

import runloop.RunLoop;

class TestTaskParallel extends Task
{
	public static var testVariable: Int = 0;
	public function new()
	{
		super();
	}

	override function subclassExecute()
	{
		testVariable++;
		Async.delay(function() {testVariable--; finish();}, 3);
	}
}

class TestTaskParallelFail extends Task
{
	public function new()
	{
		super();
	}

	override function subclassExecute()
	{
		fail();
	}
}

class ParallelTest extends unittest.TestCase
{
    public function test1()
    {
    	/// after executing, the test variable should be 10, and then after 2 seconds, back to 0
    	var taskArray:Array<Task> = [];

    	for(i in 0...10)
    	{
    		taskArray.push(new TestTaskParallel());
    	}

    	this.assertAsyncStart("test1", 8);

    	var taskGroup = new ParallelTaskGroup(taskArray);

    	taskGroup.onFinish.add(
    		function(task: Task)
    		{
	    		this.assertEquals(0, TestTaskParallel.testVariable);
	    		this.assertAsyncFinish("test1");
    		});

    	taskGroup.execute();

    	Async.delay(function() {
    		this.assertEquals(10, TestTaskParallel.testVariable);
    	}, 1);
    }

    public function test2_tryToFail()
    {
    	var taskArray:Array<Task> = [];

    	var failingTask = new TestTaskParallelFail();

    	taskArray.push(new TestTaskParallel());
    	taskArray.push(failingTask);
    	taskArray.push(new TestTaskParallel());

    	this.assertAsyncStart("test2_tryToFail", 8);

    	var taskGroup = new ParallelTaskGroup(taskArray);

    	taskGroup.onFailure.add(
    		function(task: Task)
    		{
    			assertEquals(failingTask, cast taskGroup.tasksThatFailed[0]);
    			assertEquals(1, taskGroup.tasksThatFailed.length);
    			assertAsyncFinish("test2_tryToFail");
    		});

    	taskGroup.execute();
    }
}
