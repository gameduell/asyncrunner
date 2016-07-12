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

import asyncrunner.Task;
import asyncrunner.TaskResult;

class ParallelTaskGroup extends Task
{
    private var tasksLeft: Array<Task>;

    public var tasksThatFailed(default, null): Array<Task>;
    public function new(tasks: Array<Task>) : Void
    {
        super();

        tasksLeft = tasks;
        tasksThatFailed = [];
    }

    private function taskFinished(task : Task) : Void
    {
        tasksLeft.remove(task);

        if(tasksLeft.length == 0)
        {
            endParallelTaskGroup();
        }
    }

    private function taskFailed(task : Task) : Void
    {
        tasksLeft.remove(task);

        tasksThatFailed.push(task);

        if(tasksLeft.length == 0)
        {
            endParallelTaskGroup();
        }
    }

    private function endParallelTaskGroup(): Void
    {
        if (tasksThatFailed.length == 0)
        {
            finish();
        }
        else
        {
            fail();
        }
    }

    override function subclassExecute() : Void
    {
        if (tasksLeft.length == 0)
        {
            finish();
            return;
        }
        
        for(task in tasksLeft)
        {
            task.onFinish.addOnce(taskFinished);
            task.onFailure.addOnce(taskFailed);
            runLoopForExecution.queue(task.execute, priorityForExecution);
        }
    }

    override function executeSynchronous(): Void
    {
        for (taskIndex in 0...tasksLeft.length)
        {
            var task = tasksLeft[taskIndex];

            task.executeSynchronous();

            switch (task.result)
            {
                case TaskResultFailed(failureCode, failureMessage):
                {
                    fail(failureCode, failureMessage);

                    for (i in (taskIndex + 1)...tasksLeft.length)
                    {
                        tasksLeft[i].cancel();
                    }

                    return;
                }
                default:
            }
        }

        finish();
    }

    override public function cancel(): Void
    {
        for (task in tasksLeft)
        {
            task.cancel();
        }

        super.cancel();
    }

    override public function fail(?failureCode: Int, ?failureMessage: String): Void
    {
        for (task in tasksLeft)
        {
            task.fail(failureCode, failureMessage);
        }

        super.fail(failureCode, failureMessage);
    }
}