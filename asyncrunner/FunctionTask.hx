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
    private var callFinishExecution : Bool;
    public function new(func : Void -> Void, callFinishExecution : Bool = true) : Void
    {
        super();

        this.func = func;
        this.callFinishExecution = callFinishExecution;
    }

    private function executeFuncAndExit()
    {
        func();

        if(callFinishExecution)
            finishExecution();
    }

    override function execute() : Void
    {
        runLoopForExecution.queue(executeFuncAndExit, priorityForExecution);
    }
}