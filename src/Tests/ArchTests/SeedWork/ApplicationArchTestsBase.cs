using System.Reflection;
using FluentValidation;
using MediatR;
using NetArchTest.Rules;
using Newtonsoft.Json;
using NUnit.Framework;

namespace CompanyName.MyMeetings.ArchTests.SeedWork
{
    public abstract class ApplicationArchTestsBase : TestBase
    {
        protected abstract Assembly ApplicationAssembly { get; }

        protected abstract Type CommandBaseType { get; }

        protected abstract Type CommandBaseWithResultType { get; }

        protected abstract Type InternalCommandBaseType { get; }

        protected abstract Type InternalCommandBaseWithResultType { get; }

        protected abstract Type ICommandType { get; }

        protected abstract Type ICommandWithResultType { get; }

        protected abstract Type IQueryType { get; }

        protected abstract Type ICommandHandlerType { get; }

        protected abstract Type ICommandHandlerWithResultType { get; }

        protected abstract Type IQueryHandlerType { get; }

        [Test]
        public void Command_Should_Be_Immutable()
        {
            var types = Types.InAssembly(ApplicationAssembly)
                .That()
                .Inherit(CommandBaseType)
                .Or()
                .Inherit(CommandBaseWithResultType)
                .Or()
                .Inherit(InternalCommandBaseType)
                .Or()
                .Inherit(InternalCommandBaseWithResultType)
                .Or()
                .ImplementInterface(ICommandType)
                .Or()
                .ImplementInterface(ICommandWithResultType)
                .GetTypes();

            AssertAreImmutable(types);
        }

        [Test]
        public void Query_Should_Be_Immutable()
        {
            var types = Types.InAssembly(ApplicationAssembly)
                .That().ImplementInterface(IQueryType).GetTypes();

            AssertAreImmutable(types);
        }

        [Test]
        public void CommandHandler_Should_Have_Name_EndingWith_CommandHandler()
        {
            var result = Types.InAssembly(ApplicationAssembly)
                .That()
                .ImplementInterface(ICommandHandlerType)
                    .Or()
                .ImplementInterface(ICommandHandlerWithResultType)
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
                .ImplementInterface(IQueryHandlerType)
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
                    .ImplementInterface(IQueryHandlerType)
                        .Or()
                    .ImplementInterface(ICommandHandlerType)
                        .Or()
                    .ImplementInterface(ICommandHandlerWithResultType)
                .Should().NotBePublic().GetResult().FailingTypes;

            AssertFailingTypes(types);
        }

        [Test]
        public void Validator_Should_Have_Name_EndingWith_Validator()
        {
            var result = Types.InAssembly(ApplicationAssembly)
                .That()
                .Inherit(typeof(AbstractValidator<>))
                .Should()
                .HaveNameEndingWith("Validator")
                .GetResult();

            AssertArchTestResult(result);
        }

        [Test]
        public void Validators_Should_Not_Be_Public()
        {
            var types = Types.InAssembly(ApplicationAssembly)
                .That()
                .Inherit(typeof(AbstractValidator<>))
                .Should().NotBePublic().GetResult().FailingTypes;

            AssertFailingTypes(types);
        }

        [Test]
        public void InternalCommand_Should_Have_JsonConstructorAttribute()
        {
            var types = Types.InAssembly(ApplicationAssembly)
                .That()
                .Inherit(InternalCommandBaseType)
                .Or()
                .Inherit(InternalCommandBaseWithResultType)
                .GetTypes();

            List<Type> failingTypes = [];

            foreach (var type in types)
            {
                bool hasJsonConstructorDefined = false;
                var constructors = type.GetConstructors(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
                foreach (var constructorInfo in constructors)
                {
                    var jsonConstructorAttribute = constructorInfo.GetCustomAttributes(typeof(JsonConstructorAttribute), false);
                    if (jsonConstructorAttribute.Length > 0)
                    {
                        hasJsonConstructorDefined = true;
                        break;
                    }
                }

                if (!hasJsonConstructorDefined)
                {
                    failingTypes.Add(type);
                }
            }

            AssertFailingTypes(failingTypes);
        }

        [Test]
        public void MediatR_RequestHandler_Should_NotBe_Used_Directly()
        {
            var types = Types.InAssembly(ApplicationAssembly)
                .That().DoNotHaveName("ICommandHandler`1")
                .Should().ImplementInterface(typeof(IRequestHandler<>))
                .GetTypes();

            List<Type> failingTypes = [];
            foreach (var type in types)
            {
                bool isCommandHandler = type.GetInterfaces().Any(x =>
                    x.IsGenericType &&
                    x.GetGenericTypeDefinition() == ICommandHandlerType);
                bool isCommandWithResultHandler = type.GetInterfaces().Any(x =>
                    x.IsGenericType &&
                    x.GetGenericTypeDefinition() == ICommandHandlerWithResultType);
                bool isQueryHandler = type.GetInterfaces().Any(x =>
                    x.IsGenericType &&
                    x.GetGenericTypeDefinition() == IQueryHandlerType);
                if (!isCommandHandler && !isCommandWithResultHandler && !isQueryHandler)
                {
                    failingTypes.Add(type);
                }
            }

            AssertFailingTypes(failingTypes);
        }

        [Test]
        public void Command_With_Result_Should_Not_Return_Unit()
        {
            Type commandWithResultHandlerType = ICommandHandlerWithResultType;
            IEnumerable<Type> types = Types.InAssembly(ApplicationAssembly)
                .That().ImplementInterface(commandWithResultHandlerType)
                .GetTypes().ToList();

            List<Type> failingTypes = [];
            foreach (Type type in types)
            {
                Type interfaceType = type.GetInterface(commandWithResultHandlerType.Name);
                if (interfaceType?.GenericTypeArguments[1] == typeof(Unit))
                {
                    failingTypes.Add(type);
                }
            }

            AssertFailingTypes(failingTypes);
        }
    }
}
