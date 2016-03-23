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
import asyncrunner.FunctionTask;
import asyncrunner.TaskResult;

import de.polygonal.ds.SLL;
import de.polygonal.ds.Itr;

@:allow(asyncrunner.Task)
class Async
{
    private static var tasksAndCategories: Map<Int, SLL<Task>> = new Map();
    private static var categoryIDAccum: Int = 1; /// 0 means uncategorized

    public static function run(func: Void->Void, category: TaskCategoryID = 0): FunctionTask
    {
    	var funcTask = new FunctionTask(func, false, category);
    	funcTask.execute();
    	return funcTask;
    }

    public static function delay(func: Void->Void, delaySeconds: Float, category: TaskCategoryID = 0): DelayedTask
    {
    	var delayedTask = new DelayedTask(new FunctionTask(func, false, category), delaySeconds);
    	delayedTask.execute();
    	return delayedTask;
    }

    public static function getUniqueTaskCategoryID(): Int
    {
        return categoryIDAccum++;
    }

    public static function cancelAllTasksOfCategory(taskCategory: TaskCategoryID): Void
    {
        if (!tasksAndCategories.exists(taskCategory))
            return;

        var itr: Itr<Task> = tasksAndCategories.get(taskCategory).iterator();

        while(itr.hasNext())
        {
            var existingTask = itr.next();
            existingTask.cancel();
        }

        tasksAndCategories.remove(taskCategory);
    }

    private static function addTaskToCategoryBookKeeping(task: Task): Void
    {   
        if (task.category == 0)
            return;

        var list: SLL<Task>;
        if (!tasksAndCategories.exists(task.category))
        {
            list = new SLL<Task>();
            tasksAndCategories.set(task.category, list);
        }  
        else
        {
            list = tasksAndCategories.get(task.category);
        }    

        var added = false;
        var itr: Itr<Task> = list.iterator();
        while (itr.hasNext())
        {
            var existingTask = itr.next();

            if (existingTask == task)
            {
                added = true;
            }

            if (!existingTask.isPending())
            {
                itr.remove();
            }
        }

        if (!added)
        {
            list.append(task);
        }
    }

    private static function removeTaskFromCategoryBookKeeping(task: Task): Void
    {
        if (task.category == 0)
            return;

        if (!tasksAndCategories.exists(task.category))
            return;

        tasksAndCategories.get(task.category).remove(task);    
    }
}