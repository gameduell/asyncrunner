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

import asyncrunner.Task;

import asyncrunner.ParallelTaskGroup;

import runloop.RunLoop;

class TestTaskParallel extends Task
{
	public static var testVariable: Int = 0;
	public function new()
	{
		super();
	}

	override function subclassExecute()
	{
		testVariable++;
		Async.delay(function() {testVariable--; finish();}, 3);
	}
}

class TestTaskParallelFail extends Task
{
	public function new()
	{
		super();
	}

	override function subclassExecute()
	{
		fail();
	}
}

class ParallelTest extends unittest.TestCase
{
    public function test1()
    {
    	/// after executing, the test variable should be 10, and then after 2 seconds, back to 0
    	var taskArray:Array<Task> = [];

    	for(i in 0...10)
    	{
    		taskArray.push(new TestTaskParallel());
    	}

    	this.assertAsyncStart("test1", 8);

    	var taskGroup = new ParallelTaskGroup(taskArray);

    	taskGroup.onFinish.add(
    		function(task: Task)
    		{
	    		this.assertEquals(0, TestTaskParallel.testVariable);
	    		this.assertAsyncFinish("test1");
    		});

    	taskGroup.execute();

    	Async.delay(function() {
    		this.assertEquals(10, TestTaskParallel.testVariable);
    	}, 1);
    }

    public function test2_tryToFail()
    {
    	var taskArray:Array<Task> = [];

    	var failingTask = new TestTaskParallelFail();

    	taskArray.push(new TestTaskParallel());
    	taskArray.push(failingTask);
    	taskArray.push(new TestTaskParallel());

    	this.assertAsyncStart("test2_tryToFail", 8);

    	var taskGroup = new ParallelTaskGroup(taskArray);

    	taskGroup.onFailure.add(
    		function(task: Task)
    		{
    			assertEquals(failingTask, cast taskGroup.tasksThatFailed[0]);
    			assertEquals(1, taskGroup.tasksThatFailed.length);
    			assertAsyncFinish("test2_tryToFail");
    		});

    	taskGroup.execute();
    }
}
