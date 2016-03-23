/*
 * Copyright (c) 2003-2016, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import duellkit.DuellKit;

import asyncrunner.Async;
import asyncrunner.TaskResult;

class TaskTest extends unittest.TestCase
{
    public function test1_simpleRun()
    {
        Async.run(function() assertAsyncFinish("test1_simpleRun"));

        assertAsyncStart("test1_simpleRun", 2);
    }

    public function test2_cancel()
    {
        assertShouldFail();
        var func = Async.run(function() assertAsyncFinish("test2_cancel"));

        func.cancel();

        assertAsyncStart("test2_cancel", 2);
    }

    public function test3_fail()
    {
        assertShouldFail();

        var func = Async.run(function() assertAsyncFinish("test3_fail"));

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
