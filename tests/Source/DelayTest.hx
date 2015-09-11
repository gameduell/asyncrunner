import duellkit.DuellKit;

import asyncrunner.Async;

class DelayTest extends unittest.TestCase
{
    public function test1()
    {
        var func = Async.delay(function() assertAsyncFinish("test1"), 1);

        assertAsyncStart("test1", 2);
    }
}
