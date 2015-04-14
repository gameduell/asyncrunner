import duell.DuellKit;

import asyncrunner.Async;
import asyncrunner.TaskResult;

class ComplexTest extends unittest.TestCase
{
    public function test1_cancelAllFromCategoryMoreComplex()
    {
        var counter = 10;

        /// This function is scheduled to be executed 5 times with one category, and 5 times with another.
        /// Only one category should be succesfully executed, so in the end the counter should be 5
        var countDownFunction = function() counter--;

        var categoryToBeSuccessful = Async.getUniqueTaskCategoryID();
        var categoryToBeCancelled = Async.getUniqueTaskCategoryID();

        for (i in 0...5)
        {
            Async.run(countDownFunction, categoryToBeSuccessful);
            Async.run(countDownFunction, categoryToBeCancelled);
        }

        Async.cancelAllTasksOfCategory(categoryToBeCancelled);

        this.assertAsyncStart("test1_cancelAllFromCategoryMoreComplex", 3);

        Async.delay(function() {
            assertEquals(5, counter);
            assertAsyncFinish("test1_cancelAllFromCategoryMoreComplex");
        }, 2);
    }
}
