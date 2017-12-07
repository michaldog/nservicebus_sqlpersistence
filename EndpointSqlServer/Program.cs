using System;
using System.Data.SqlClient;
using System.Threading.Tasks;
using NServiceBus;
using NServiceBus.Persistence;
using NServiceBus.Persistence.Sql;

class Program
{
    static async Task Main()
    {
        Console.Title = "Samples.SqlPersistence.EndpointSqlServer";

        #region sqlServerConfig

        var endpointConfiguration = new EndpointConfiguration("Samples.SqlPersistence.EndpointSqlServer");

        
        var sqlPersistence = endpointConfiguration.UsePersistence<SqlPersistence>();
        var connection = @"Data Source=(LocalDB)\MSSQLLocalDB;Initial Catalog=NsbSamplesSqlPersistence;Integrated Security=True";

        // Michal 07.12.2017: Adding this line causes a "The endpoint has not been configured to use SQL persistence" exception to be thrown
        var ravenDbPersistence = endpointConfiguration.UsePersistence<RavenDBPersistence, StorageType.Timeouts>();
        //////////////////////////////////////////////////////

        sqlPersistence.SqlDialect<SqlDialect.MsSqlServer>();
        sqlPersistence.ConnectionBuilder(
            connectionBuilder: () =>
            {
                return new SqlConnection(connection);
            });
        var subscriptions = sqlPersistence.SubscriptionSettings();
        subscriptions.CacheFor(TimeSpan.FromMinutes(1));

        #endregion

        SqlHelper.EnsureDatabaseExists(connection);

        endpointConfiguration.UseTransport<LearningTransport>();
        endpointConfiguration.EnableInstallers();

        var endpointInstance = await Endpoint.Start(endpointConfiguration)
            .ConfigureAwait(false);

        Console.WriteLine("Press any key to exit");
        Console.ReadKey();

        await endpointInstance.Stop()
            .ConfigureAwait(false);
    }
}