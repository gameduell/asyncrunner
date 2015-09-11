import duellkit.DuellKit;

import asyncrunner.Async;

import asyncrunner.Task;

import asyncrunner.SequentialTaskGroup;

import runloop.RunLoop;
import runloop.Priority;

class TestTaskSequential extends Task
{
	public static var testVariable: Int = 0;
	public function new()
	{
		super();
        this.priorityForExecution = PriorityASAP;
        this.priorityForFinishing = PriorityASAP;
	}

	override public function subclassExecute()
	{
		testVariable++;
		Async.delay(function() finish(), 3.0);
	}
}

class TestTaskSequentialFail extends Task
{
    public function new()
    {
        super();
        this.priorityForExecution = PriorityASAP;
        this.priorityForFinishing = PriorityASAP;
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
        TestTaskSequential.testVariable = 0;
    	var taskArray:Array<Task> = [];

    	for(i in 0...5)
    	{
    		taskArray.push(new TestTaskSequential());
    	}

    	this.assertAsyncStart("test1", 20);

    	var taskGroup = new SequentialTaskGroup(taskArray);

    	taskGroup.onFinish.add(
    		function(task: Task)
    		{
	    		assertEquals(5, TestTaskSequential.testVariable);
	    		assertAsyncFinish("test1");
    		});

    	taskGroup.execute();

        Async.delay(function() assertEquals(1, TestTaskSequential.testVariable), 1.5);
        Async.delay(function() assertEquals(2, TestTaskSequential.testVariable), 4.5);
        Async.delay(function() assertEquals(3, TestTaskSequential.testVariable), 7.5);
        Async.delay(function() assertEquals(4, TestTaskSequential.testVariable), 10.5);
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

        this.assertAsyncStart("test2_tryToFail", 8.0);

        var taskGroup = new SequentialTaskGroup(taskArray);
        taskGroup.execute();

        Async.delay(function()
        {
            assertTrue(Type.enumEq(successTask.result, TaskResultSuccessful));
            assertTrue(Type.enumEq(cancelledTask.result, TaskResultCancelled));
            assertTrue(Type.enumEq(failingTask.result, TaskResultFailed(0, "test")));
            assertAsyncFinish("test2_tryToFail");
        }, 6.0);
    }
}
