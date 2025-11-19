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
        protected static void MediatR_RequestHandler_Should_NotBe_Used_Directly(Assembly applicationAssembly, Type commandHandlerType, Type commandWithResultHandlerType, Type queryHandlerType)
        {
            var types = Types.InAssembly(applicationAssembly)
                .That().DoNotHaveName("ICommandHandler`1")
                .Should().ImplementInterface(typeof(IRequestHandler<>))
                .GetTypes();

            List<Type> failingTypes = [];
            foreach (var type in types)
            {
                bool isCommandHandler = type.GetInterfaces().Any(x =>
                    x.IsGenericType &&
                    x.GetGenericTypeDefinition() == commandHandlerType);
                bool isCommandWithResultHandler = type.GetInterfaces().Any(x =>
                    x.IsGenericType &&
                    x.GetGenericTypeDefinition() == commandWithResultHandlerType);
                bool isQueryHandler = type.GetInterfaces().Any(x =>
                    x.IsGenericType &&
                    x.GetGenericTypeDefinition() == queryHandlerType);
                if (!isCommandHandler && !isCommandWithResultHandler && !isQueryHandler)
                {
                    failingTypes.Add(type);
                }
            }

            AssertFailingTypes(failingTypes);
        }

        protected static void Command_With_Result_Should_Not_Return_Unit(Assembly applicationAssembly, Type commandWithResultHandlerType)
        {
            IEnumerable<Type> types = Types.InAssembly(applicationAssembly)
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

        protected static void InternalCommand_Should_Have_JsonConstructorAttribute(Assembly applicationAssembly, Type internalCommandBaseType, Type internalCommandBaseGenericType)
        {
            var types = Types.InAssembly(applicationAssembly)
                .That()
                .Inherit(internalCommandBaseType)
                .Or()
                .Inherit(internalCommandBaseGenericType)
                .GetTypes();

            List<Type> failingTypes = [];

            foreach (var type in types)
            {
                bool hasJsonConstructorDefined = false;
                var constructors = type.GetConstructors(BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.Instance);
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

        protected static void Validator_Should_Have_Name_EndingWith_Validator(Assembly applicationAssembly)
        {
            var result = Types.InAssembly(applicationAssembly)
                .That()
                .Inherit(typeof(AbstractValidator<>))
                .Should()
                .HaveNameEndingWith("Validator")
                .GetResult();

            AssertArchTestResult(result);
        }

        protected static void Validators_Should_Not_Be_Public(Assembly applicationAssembly)
        {
            var types = Types.InAssembly(applicationAssembly)
                .That()
                .Inherit(typeof(AbstractValidator<>))
                .Should().NotBePublic().GetResult().FailingTypes;

            AssertFailingTypes(types);
        }
    }
}
