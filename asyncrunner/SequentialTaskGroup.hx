/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 02/07/14
 * Time: 12:30
 */
package asyncrunner;

import asyncrunner.Task;

class SequentialTaskGroup extends Task
{
    private var taskQueue : Array<Task>;
    private var currentTaskIndex : Int;
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
            finishExecution();
        }
        else
        {
            executeTaskAtIndex();
        }
    }

    private function executeTaskAtIndex()
    {
        var currentTask = taskQueue[currentTaskIndex];

        currentTask.onFinish.addOnce(taskFinished);
        runLoopForExecution.queue(currentTask.execute, priorityForExecution);
    }

    override function execute() : Void
    {
        currentTaskIndex = 0;

        if(taskQueue.length == 0)
        {
            finishExecution();
        }
        else
        {
            executeTaskAtIndex();
        }
    }
}