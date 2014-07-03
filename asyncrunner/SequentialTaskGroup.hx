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
            RunLoop.getCurrentLoop().queue1(onFinish.dispatch, this, priority);
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
        RunLoop.getCurrentLoop().queue(currentTask.execute, priority);
    }

    override function execute() : Void
    {
        currentTaskIndex = 0;

        if(taskQueue.length == 0)
        {
            RunLoop.getCurrentLoop().queue1(onFinish.dispatch, this, priority);
        }
        else
        {
            executeTaskAtIndex();
        }
    }
}