/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 02/07/14
 * Time: 16:26
 */
package asyncrunner;

import runloop.MainRunLoop;

class DelayedTask extends Task
{
    /// WARNING priorities are pointless here because delays always execute
    /// the priority can however be defined in the task given by the constructor
    private var task : Task;
    private var delaySeconds : Float;
    public function new(task : Task, delaySeconds : Float) : Void
    {
        super();

        this.task = task;
        this.delaySeconds = delaySeconds;
    }

    override function execute() : Void
    {
        RunLoop.getMainLoop().delay(task.execute, delaySeconds);
    }

    /// Helpers!
    public static function delay(func : Void->Void, delaySeconds : Float)
    {
        RunLoop.getMainLoop().delay(func, delaySeconds);
    } 
}