using System.Reflection;
using CompanyName.MyMeetings.Modules.UserAccess.Application.Configuration.Commands;
using CompanyName.MyMeetings.Modules.UserAccess.Application.Configuration.Queries;
using CompanyName.MyMeetings.Modules.UserAccess.Application.Contracts;
using NUnit.Framework;

namespace CompanyName.MyMeetings.Modules.UserAccess.ArchTests.Application
{
    [TestFixture]
    public class ApplicationTests : global::CompanyName.MyMeetings.ArchTests.SeedWork.ApplicationArchTestsBase
    {
        protected override Assembly ApplicationAssembly => typeof(IUserAccessModule).Assembly;

        protected override Type CommandBaseType => typeof(CommandBase);

        protected override Type CommandBaseWithResultType => typeof(CommandBase<>);

        protected override Type InternalCommandBaseType => typeof(InternalCommandBase);

        protected override Type InternalCommandBaseWithResultType => typeof(InternalCommandBase<>);

        protected override Type ICommandType => typeof(ICommand);

        protected override Type ICommandWithResultType => typeof(ICommand<>);

        protected override Type IQueryType => typeof(IQuery<>);

        protected override Type ICommandHandlerType => typeof(ICommandHandler<>);

        protected override Type ICommandHandlerWithResultType => typeof(ICommandHandler<,>);

        protected override Type IQueryHandlerType => typeof(IQueryHandler<,>);
    }
}
