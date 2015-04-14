import duell.DuellKit;

import asyncrunner.Async;
import asyncrunner.TaskResult;

class TaskTest extends unittest.TestCase
{
    public function test1_simpleRun()
    {
        Async.run(function() assertAsyncFinish(test1_simpleRun));

        assertAsyncStart("test1_simpleRun", 2);
    }

    public function test2_cancel()
    {
        assertShouldFail();
        var func = Async.run(function() assertAsyncFinish(test2_cancel));

        func.cancel();

        assertAsyncStart("test2_cancel", 2);
    }

    public function test3_fail()
    {
        assertShouldFail();

        var func = Async.run(function() assertAsyncFinish(test3_fail));

        func.fail(0, null);

        assertAsyncStart("test3_fail", 2);
    }

    public function test4_failMessage()
    {
        var failMessage = "an errorMessage";
        var failCode = 255;

        var func = Async.run(function() assertAsyncFinish("test3_fail"));

        func.fail(failCode, failMessage);

        assertTrue(Type.enumEq(TaskResultFailed(failCode, failMessage), func.result));
    }


    public function test5_cancelAllFromCategory()
    {
        var category = Async.getUniqueTaskCategoryID();
        assertShouldFail();

        Async.run(function() assertAsyncFinish("test5_cancelAllFromCategory"), category);
        Async.cancelAllTasksOfCategory(category);

        assertAsyncStart("test5_cancelAllFromCategory", 2);
    }
}
