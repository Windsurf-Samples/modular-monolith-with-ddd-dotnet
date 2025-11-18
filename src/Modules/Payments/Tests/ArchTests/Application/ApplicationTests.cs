using System.Reflection;
using CompanyName.MyMeetings.ArchTests.SeedWork;
using CompanyName.MyMeetings.Modules.Payments.Application.Configuration.Commands;
using CompanyName.MyMeetings.Modules.Payments.Application.Configuration.Queries;
using CompanyName.MyMeetings.Modules.Payments.Application.Contracts;
using FluentValidation;
using MediatR;
using NetArchTest.Rules;
using NUnit.Framework;

namespace CompanyName.MyMeetings.Modules.Payments.ArchTests.Application
{
    [TestFixture]
    public class ApplicationTests : ApplicationArchTestsBase
    {
        private static Assembly ApplicationAssembly => typeof(CommandBase).Assembly;

        [Test]
        public void Command_Should_Be_Immutable()
        {
            var types = Types.InAssembly(ApplicationAssembly)
                .That()
                .Inherit(typeof(CommandBase))
                .Or()
                .Inherit(typeof(CommandBase<>))
                .Or()
                .Inherit(typeof(InternalCommandBase))
                .Or()
                .Inherit(typeof(InternalCommandBase<>))
                .Or()
                .ImplementInterface(typeof(ICommand))
                .Or()
                .ImplementInterface(typeof(ICommand<>))
                .GetTypes();

            AssertAreImmutable(types);
        }

        [Test]
        public void Query_Should_Be_Immutable()
        {
            var types = Types.InAssembly(ApplicationAssembly)
                .That().ImplementInterface(typeof(IQuery<>)).GetTypes();

            AssertAreImmutable(types);
        }

        [Test]
        public void CommandHandler_Should_Have_Name_EndingWith_CommandHandler()
        {
            var result = Types.InAssembly(ApplicationAssembly)
                .That()
                .ImplementInterface(typeof(ICommandHandler<>))
                    .Or()
                .ImplementInterface(typeof(ICommandHandler<,>))
                .And()
                .DoNotHaveNameMatching(".*Decorator.*").Should()
                .HaveNameEndingWith("CommandHandler")
                .GetResult();

            AssertArchTestResult(result);
        }

        [Test]
        public void QueryHandler_Should_Have_Name_EndingWith_QueryHandler()
        {
            var result = Types.InAssembly(ApplicationAssembly)
                .That()
                .ImplementInterface(typeof(IQueryHandler<,>))
                .Should()
                .HaveNameEndingWith("QueryHandler")
                .GetResult();

            AssertArchTestResult(result);
        }

        [Test]
        public void Command_And_Query_Handlers_Should_Not_Be_Public()
        {
            var types = Types.InAssembly(ApplicationAssembly)
                .That()
                    .ImplementInterface(typeof(IQueryHandler<,>))
                        .Or()
                    .ImplementInterface(typeof(ICommandHandler<>))
                        .Or()
                    .ImplementInterface(typeof(ICommandHandler<,>))
                .Should().NotBePublic().GetResult().FailingTypes;

            AssertFailingTypes(types);
        }

        [Test]
        public void InternalCommand_Should_Have_JsonConstructorAttribute()
        {
            InternalCommand_Should_Have_JsonConstructorAttribute(
                ApplicationAssembly,
                typeof(InternalCommandBase),
                typeof(InternalCommandBase<>));
        }

        [Test]
        public void MediatR_RequestHandler_Should_NotBe_Used_Directly()
        {
            MediatR_RequestHandler_Should_NotBe_Used_Directly(
                ApplicationAssembly,
                typeof(ICommandHandler<>),
                typeof(ICommandHandler<,>),
                typeof(IQueryHandler<,>));
        }

        [Test]
        public void Command_With_Result_Should_Not_Return_Unit()
        {
            Command_With_Result_Should_Not_Return_Unit(
                ApplicationAssembly,
                typeof(ICommandHandler<,>));
        }

        [Test]
        public void Validator_Should_Have_Name_EndingWith_Validator()
        {
            Validator_Should_Have_Name_EndingWith_Validator(ApplicationAssembly);
        }

        [Test]
        public void Validators_Should_Not_Be_Public()
        {
            Validators_Should_Not_Be_Public(ApplicationAssembly);
        }
    }
}
