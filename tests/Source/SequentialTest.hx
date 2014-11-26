import duell.DuellKit;

import asyncrunner.Async;

import asyncrunner.Task;

import asyncrunner.SequentialTaskGroup;

class TestTaskSequential extends Task
{
	public static var testVariable: Int = 0;
	public function new()
	{
		super();
	}

	override public function subclassExecute()
	{
		testVariable++;
		Async.delay(function() finish(), 1.0);
	}
}

class TestTaskSequentialFail extends Task
{
    public function new()
    {
        super();
    }

    override function subclassExecute()
    {
        fail(0, "test");
    }
}

class SequentialTest extends unittest.TestCase
{
    public function test1()
    {
    	/// after executing, the test variable should be 10, and then after 2 seconds, back to 0
    	var taskArray:Array<Task> = [];

    	for(i in 0...5)
    	{
    		taskArray.push(new TestTaskSequential());
    	}

    	this.assertAsyncStart(test1, 6);

    	var taskGroup = new SequentialTaskGroup(taskArray);

    	taskGroup.onFinish.add(
    		function(task: Task)
    		{
	    		assertEquals(5, TestTaskSequential.testVariable);
	    		assertAsyncFinish(test1);
    		});

    	taskGroup.execute();

        Async.delay(function() assertEquals(1, TestTaskSequential.testVariable), 0.5);
        Async.delay(function() assertEquals(2, TestTaskSequential.testVariable), 1.5);
        Async.delay(function() assertEquals(3, TestTaskSequential.testVariable), 2.5);
        Async.delay(function() assertEquals(4, TestTaskSequential.testVariable), 3.5);
    }


    public function test2_tryToFail()
    {
        var taskArray:Array<Task> = [];

        var successTask = new TestTaskSequential();
        var failingTask = new TestTaskSequentialFail();
        var cancelledTask = new TestTaskSequential();

        taskArray.push(successTask);
        taskArray.push(failingTask);
        taskArray.push(cancelledTask);

        this.assertAsyncStart(test2_tryToFail, 4.0);

        var taskGroup = new SequentialTaskGroup(taskArray);
        taskGroup.execute();

        Async.delay(function()
        {
            //assertTrue(Type.enumEq(successTask.result, TaskResultSuccessful));
            //assertTrue(Type.enumEq(cancelledTask.result, TaskResultCancelled));
            //assertTrue(Type.enumEq(failingTask.result, TaskResultFailed(0, "test")));
            assertAsyncFinish(test2_tryToFail);
        }, 2.0);
    }
}
