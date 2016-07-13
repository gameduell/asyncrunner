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

package asyncrunner;

import asyncrunner.TaskCategoryID;
import asyncrunner.Task;

class FunctionWrapperTask extends Task
{
    private var func: Void -> Task;
    public function new(func: Void -> Task, category: TaskCategoryID = 0): Void
    {
        super(category);

        this.func = func;
    }

    override function subclassExecute(): Void
    {
        runLoopForExecution.queue(executeFuncAndExit.bind(true), priorityForExecution);
    }

    override function executeSynchronous(): Void
    {
        executeFuncAndExit(true);
    }

    private function executeFuncAndExit(synchronous: Bool): Void
    {
        switch(result)
        {
            case TaskResultCancelled,
                 TaskResultFailed(_, _),
                 TaskResultSuccessful:
                return;
            case TaskResultPending:

                var task = func();

                task.onFinish.addOnce(taskFinished);
                task.onFailure.addOnce(taskFailed);
                if (synchronous)
                {
                    task.executeSynchronous();
                }
                else
                {
                    task.execute();
                }

                return;
        }
    }

    private function taskFailed(task : Task) : Void
    {
        switch (task.result)
        {
            case TaskResultFailed(failureCode, failureMessage):
            {
                fail(failureCode, failureMessage);
            }
            default:
                throw "Incorrect internal state of asyncrunner, task called failed, when it wasn't";
        }
    }

    private function taskFinished(task : Task) : Void
    {
        finish();
    }

    override function set_result(newResult: TaskResult): TaskResult
    {
        switch ([result, newResult])
        {
            case [TaskResultPending, _]:
                result = newResult;
            default:
                throw "Incorrect state on task, task result should only go from pending to any other state";
        }

        switch(result)
        {
            case TaskResultPending:
            default:
                func = null;
        }

        return result;
    }
}