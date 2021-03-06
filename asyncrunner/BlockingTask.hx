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

class BlockingTask extends Task
{
    private var blocked: Bool;
    private var executeCalled: Bool;
    public function new(): Void
    {
        super(category);

        blocked = true;
        executeCalled = false;
    }

    public function unblock(): Void
    {
        blocked = false;

        if (executeCalled)
        {
            callFinish();
        }
    }

    private function callFinish(): Void
    {
        switch(result)
        {
            case TaskResultCancelled,
                 TaskResultFailed(_, _),
                 TaskResultSuccessful:
                return;
            case TaskResultPending:

                finish();
                return;
        }
    }

    override function subclassExecute(): Void
    {
        executeCalled = true;
        if (!blocked)
        {
            callFinish();
        }
    }

    override function executeSynchronous(): Void
    {
        executeCalled = true;
        if (!blocked)
        {
            callFinish();
        }
    }
}