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

import runloop.RunLoop;

import asyncrunner.Task;

class DelayedTask extends Task
{
    /// WARNING priorities are pointless here because delays always execute
    /// the priority can however be defined in the task given by the constructor
    public var task(default, null): Task;
    private var delaySeconds: Float;

    public function new(taskToDelay: Task, delaySeconds: Float) : Void
    {
        /// the super runs setters, so do this first
        task = taskToDelay;

        super(taskToDelay.category);

        this.delaySeconds = delaySeconds;

        taskToDelay.onFinish.add(this.onFinish.dispatch);
        taskToDelay.onFailure.add(this.onFailure.dispatch);
    }

	private function cleanup(): Void
	{
		task.onFinish.remove(this.onFinish.dispatch);
        task.onFailure.remove(this.onFailure.dispatch);
	}

    override function subclassExecute(): Void
    {
        RunLoop.getMainLoop().delay(task.subclassExecute, delaySeconds);
    }

    override function subclassExecuteSynchronous(): Void
    {
        task.subclassExecuteSynchronous();
    }

    override public function cancel(): Void
    {
        task.cancel();
		cleanup();
    }

    override public function fail(?failureCode: Int, ?failureMessage: String): Void
    {
        task.fail();
		cleanup();
    }

    override public function finish(): Void
    {
        task.finish();
		cleanup();
    }

    override public function isPending(): Bool
    {
        return task.isPending();
    }


    override public function isCallbacksEnabled(): Bool
    {
        return task.callbacksEnabled;
    }

    override private function set_callbacksEnabled(bool: Bool): Bool
    {
        return (task.callbacksEnabled = bool);
    }

    override function get_result(): TaskResult
    {
        return task.result;
    }

    override function set_result(newResult: TaskResult): TaskResult
    {
        return (task.result = newResult);
    }
}
