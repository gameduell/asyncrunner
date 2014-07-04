/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 02/07/14
 * Time: 12:27
 */
package asyncrunner;

import asyncrunner.Task;

class ParallelTaskGroup extends Task
{
    private var tasksLeft : Array<Task>;
    public function new(tasks : Array<Task>) : Void
    {
        super();

        tasksLeft = tasks;
    }

    private function taskFinished(task : Task) : Void
    {
        tasksLeft.remove(task);

        if(tasksLeft.length == 0)
        {
            runLoopForFinishing.queue1(onFinish.dispatch, this, priorityForFinishing);
        }
    }

    override function execute() : Void
    {
        for(task in tasksLeft)
        {
            task.onFinish.addOnce(taskFinished);
            runLoopForExecution.queue(task.execute, priorityForExecution);
        }
    }
}