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

class SequentialTaskGroup extends Task
{
    private var taskQueue : Array<Task>;
    private var currentTaskIndex : Int;

    public var failingTask(default, null): Task;
    public function new(tasks : Array<Task>) : Void
    {
        super();

        taskQueue = tasks;
        currentTaskIndex = 0;
    }

    private function taskFinished(task : Task) : Void
    {
        ++currentTaskIndex;

        if(currentTaskIndex >= taskQueue.length)
        {
            finish();
        }
        else
        {
            executeTaskAtIndex();
        }
    }

    private function taskFailed(task : Task) : Void
    {
        failingTask = task;
        switch (task.result)
        {
            case TaskResultFailed(failureCode, failureMessage):
            {
                fail(failureCode, failureMessage);
            }
            default:
                throw "Incorrect internal state of asyncrunner, task called failed, when it wasn't";
        }

        currentTaskIndex++;
        for (i in currentTaskIndex...taskQueue.length)
        {
            taskQueue[i].cancel();
        }
    }

    private function executeTaskAtIndex()
    {
        var currentTask = taskQueue[currentTaskIndex];

        currentTask.onFinish.addOnce(taskFinished);
        currentTask.onFailure.addOnce(taskFailed);

        currentTask.execute();
    }

    override function cancel(): Void
    {
        for (i in currentTaskIndex...taskQueue.length)
        {
            taskQueue[i].cancel();
        }

        super.cancel();
    }

    override function executeSynchronous(): Void
    {
        var taskIndex = 0;
        while (taskIndex < taskQueue.length)
        {
            var task = taskQueue[taskIndex++];

            task.executeSynchronous();

            switch (task.result)
            {
                case TaskResultFailed(failureCode, failureMessage):
                {
                    fail(failureCode, failureMessage);

                    for (i in (taskIndex + 1)...taskQueue.length)
                    {
                        taskQueue[i].cancel();
                    }

                    return;
                }
                default:
            }
        }

        finish();
    }

    override function subclassExecute() : Void
    {
        currentTaskIndex = 0;

        if (taskQueue.length == 0)
        {
            finish();
        }
        else
        {
            executeTaskAtIndex();
        }
    }
}
