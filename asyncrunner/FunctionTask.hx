/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 02/07/14
 * Time: 16:26
 */
package asyncrunner;

class FunctionTask extends Task
{
    private var func : Void -> Void;
    public function new(func : Void -> Void) : Void
    {
        super();

        this.func = func;
    }

    private function executeFuncAndExit()
    {
        func();
        onFinish.dispatch(this);
    }

    override function execute() : Void
    {
        RunLoop.getCurrentLoop().queue1(executeFuncAndExit, this, priority);
    }
}