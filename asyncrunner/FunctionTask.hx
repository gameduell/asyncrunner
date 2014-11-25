/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 02/07/14
 * Time: 16:26
 */
package asyncrunner;

import asyncrunner.TaskCategoryID;
import asyncrunner.Task;

class FunctionTask extends Task
{
    private var func: Void -> Void;
    private var callFinish: Bool;
    public function new(func: Void -> Void, callFinish: Bool = true, category: TaskCategoryID = 0): Void
    {
        super(category);

        this.func = func;
        this.callFinish = callFinish;
    }

    override function subclassExecute(): Void
    {
        runLoopForExecution.queue(executeFuncAndExit, priorityForExecution);
    }

    private function executeFuncAndExit(): Void
    {
        switch(result)
        {
            case TaskResultCancelled, 
                 TaskResultFailed(_, _),
                 TaskResultSuccessful:
                return;
            case TaskResultPending:

                func();

                if(callFinish)
                {
                    finish();
                }

                return;
        }
    }

    override function set_result(newResult: TaskResult): TaskResult
    {
        switch ([result, newResult]) 
        {
            case [TaskResultPending, _]:
                result = newResult;
            default:
                throw "Incorrect state on task, task result should only go from pending to any other state"; 
        }

        switch(result)
        {
            case TaskResultPending:
            default:
                func = null;
        }

        return result;
    }
}