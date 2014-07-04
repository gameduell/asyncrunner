/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 02/07/14
 * Time: 12:27
 */
package asyncrunner;

import msignal.Signal.Signal1;
import asyncrunner.Priority;

class Task
{
    private function new()
    {
        onFinish = new Signal1<Task>();
        priorityForExecution = PriorityLow;
        priorityForFinishing = PriorityLow;
        runLoopForExecution = RunLoop.getMainLoop();
        runLoopForFinishing = RunLoop.getMainLoop();
    }

    ///should be overridden by subclasses
    public function execute() : Void
    {
        runLoopForFinishing.queue1(onFinish.dispatch, this, priorityForFinishing);
    }

    /// is called when the task completes its execution
    public var onFinish : Signal1<Task>;

    public var priorityForExecution : Priority;
    public var priorityForFinishing : Priority;

    public var runLoopForExecution : RunLoop;
    public var runLoopForFinishing : RunLoop;

    ///arbitrarily place things here that are meant to represent the result of the task
    public var data : Dynamic;
}