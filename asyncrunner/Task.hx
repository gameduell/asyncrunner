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
        priority = PriorityLow;
    }

    ///should be overridden by subclasses
    public function execute() : Void
    {
        onFinish.dispatch(self);
    }

    /// is called when the task completes its execution
    public var onFinish : Signal1<Task>;
    public var priority : Priority;
}