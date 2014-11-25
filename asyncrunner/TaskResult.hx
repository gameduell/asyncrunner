package asyncrunner;

enum TaskResult
{
	TaskResultPending;
	TaskResultCancelled;
	TaskResultFailed(failureCode: Int, failureMessage: String);
	TaskResultSuccessful;
}