FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["BoxH2O.Api/BoxH2O.Api.csproj", "BoxH2O.Api/"]
RUN dotnet restore "BoxH2O.Api/BoxH2O.Api.csproj"
COPY . .
WORKDIR "/src/BoxH2O.Api"
RUN dotnet build "BoxH2O.Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "BoxH2O.Api.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "BoxH2O.Api.dll"]