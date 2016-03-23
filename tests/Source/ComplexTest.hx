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

class ComplexTest extends unittest.TestCase
{
    public function test1_cancelAllFromCategoryMoreComplex()
    {
        assertTrue(true);
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
