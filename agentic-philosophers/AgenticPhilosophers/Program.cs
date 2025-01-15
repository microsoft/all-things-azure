/// <summary>
/// This is the main program class that starts the debate between agentic philosophers.
/// </summary>
class Program
{
    static async Task Main()
    {        
        var philosophers = new AgentDebate();

        // Start the debate on a specific topic
        await philosophers.DebateAsync("How can we ensure that AI benefits all of humanity?");   
    }    
}



