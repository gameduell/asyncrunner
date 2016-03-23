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

import msignal.Signal.Signal1;

import asyncrunner.TaskResult;
import asyncrunner.TaskCategoryID;
import asyncrunner.Async;

import runloop.Priority;
import runloop.RunLoop;

class Task
{
    /// is called when the task completes its execution
    public var onFinish : Signal1<Task>;
    public var onFailure : Signal1<Task>;

    public var priorityForExecution : Priority;
    public var priorityForFinishing : Priority;

    public var runLoopForExecution : RunLoop;
    public var runLoopForFinishing : RunLoop;

    @:isVar
    public var result(get, set): TaskResult = TaskResultPending;
    
    public var category(default, null): TaskCategoryID = 0;

    public var callbacksEnabled(null, set): Bool = true;

    public function new(category: TaskCategoryID = 0)
    {
        result = TaskResultPending;
        this.category = category;
        onFinish = new Signal1<Task>();
        onFailure = new Signal1<Task>();
        priorityForExecution = PriorityLow;
        priorityForFinishing = PriorityLow;
        runLoopForExecution = RunLoop.getMainLoop();
        runLoopForFinishing = RunLoop.getMainLoop();

        Async.addTaskToCategoryBookKeeping(this);
    }

    public function execute(): Void 
    {
        switch(result)
        {
            case TaskResultCancelled, 
                 TaskResultFailed(_, _),
                 TaskResultSuccessful:
                return;
            case TaskResultPending:
                subclassExecute();
                return;
        }
    }

    ///should be overridden
    private function subclassExecute()
    {

    }

    public function cancel(): Void
    {
        switch(result)
        {
            case TaskResultSuccessful,
                 TaskResultCancelled,
                 TaskResultFailed(_, _):
                return;
            case TaskResultPending:
                result = TaskResultCancelled;
                return;
        }
    }

    public function fail(?failureCode: Int, ?failureMessage: String): Void
    {
        switch(result)
        {
            case TaskResultPending:
                result = TaskResultFailed(failureCode, failureMessage);
                callFailCallback();
                return;
            default:
                return;
        }
    }

    public function finish(): Void
    {
        switch(result)
        {
            case TaskResultPending:
                result = TaskResultSuccessful;
                callFinishCallback();
                return;
            default:
                return;
        }
    }

    public function isPending(): Bool
    {
        return result == TaskResultPending;
    }

    private function callFinishCallback(): Void
    {
        if (isCallbacksEnabled())
        {
            runLoopForFinishing.queue1(onFinish.dispatch, this, priorityForFinishing);
        }
    }

    private function callFailCallback(): Void
    {
        if (isCallbacksEnabled())
        {
            runLoopForFinishing.queue1(onFailure.dispatch, this, priorityForFinishing);
        }
    }

    public function isCallbacksEnabled(): Bool
    {
        return callbacksEnabled;
    }

    private function set_callbacksEnabled(bool: Bool): Bool
    {
        return (callbacksEnabled = bool);
    }

    private function set_result(newResult: TaskResult): TaskResult
    {
        switch ([result, newResult]) 
        {
            case [TaskResultPending, _]:
                result = newResult;
            default:
                throw "Incorrect state on task, task result should only go from pending to any other state"; 
        }

        return result;
    }

    private function get_result(): TaskResult
    {
        return result;
    }
}