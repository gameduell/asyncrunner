/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 02/07/14
 * Time: 12:27
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
        for(task in tasksLeft)
        {
            task.onFinish.addOnce(taskFinished);
            task.onFailure.addOnce(taskFailed);
            runLoopForExecution.queue(task.execute, priorityForExecution);
        }
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