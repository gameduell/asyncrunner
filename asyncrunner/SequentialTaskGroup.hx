/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 02/07/14
 * Time: 12:30
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
        runLoopForExecution.queue(currentTask.execute, priorityForExecution);
    }

    override function subclassExecute() : Void
    {
        currentTaskIndex = 0;

        if(taskQueue.length == 0)
        {
            finish();
        }
        else
        {
            executeTaskAtIndex();
        }
    }
}