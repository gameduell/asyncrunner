/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 02/07/14
 * Time: 16:26
 */
package asyncrunner;

import runloop.RunLoop;

import asyncrunner.Task;

class DelayedTask extends Task
{
    /// WARNING priorities are pointless here because delays always execute
    /// the priority can however be defined in the task given by the constructor
    public var task(default, null): Task;
    private var delaySeconds: Float;

    public function new(taskToDelay: Task, delaySeconds: Float) : Void
    {
        /// the super runs setters, so do this first
        task = taskToDelay;

        super(taskToDelay.category);
        
        this.delaySeconds = delaySeconds;

        taskToDelay.onFinish.add(this.onFinish.dispatch);
        taskToDelay.onFailure.add(this.onFailure.dispatch);
    }

    override function subclassExecute(): Void
    {
        RunLoop.getMainLoop().delay(task.execute, delaySeconds);
    }

    override public function cancel(): Void
    {
        task.cancel();
    }

    override public function fail(?failureCode: Int, ?failureMessage: String): Void
    {
        task.fail();
    }

    override public function finish(): Void
    {
        task.finish();
    }

    override public function isPending(): Bool
    {
        return task.isPending();
    }


    override public function isCallbacksEnabled(): Bool
    {
        return task.callbacksEnabled;
    }

    override private function set_callbacksEnabled(bool: Bool): Bool
    {
        return (task.callbacksEnabled = bool);
    }

    override function get_result(): TaskResult
    {
        return task.result;
    }

    override function set_result(newResult: TaskResult): TaskResult
    {
        return (task.result = newResult);
    }
}