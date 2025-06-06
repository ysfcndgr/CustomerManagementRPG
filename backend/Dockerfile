# Use the official .NET 6.0 runtime as base image
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Install ODBC drivers for AS400 connectivity
RUN apt-get update && apt-get install -y \
    unixodbc \
    unixodbc-dev \
    curl \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Download and install IBM i Access ODBC Driver (for production AS400 connectivity)
# Note: This requires IBM i Access license. For development, we'll use mock service.
# RUN curl -O https://public.dhe.ibm.com/software/ibmi/products/odbc/debs/dists/1.1.0/ibmi-acs-1.1.0.list
# RUN cp ibmi-acs-1.1.0.list /etc/apt/sources.list.d/
# RUN apt-get update && apt-get install -y ibmi-acs

# Use the SDK image for building
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

# Copy csproj files and restore dependencies
COPY ["CustomerUpdate.API/CustomerUpdate.API.csproj", "CustomerUpdate.API/"]
COPY ["CustomerUpdate.Core/CustomerUpdate.Core.csproj", "CustomerUpdate.Core/"]
COPY ["CustomerUpdate.Infrastructure/CustomerUpdate.Infrastructure.csproj", "CustomerUpdate.Infrastructure/"]

RUN dotnet restore "CustomerUpdate.API/CustomerUpdate.API.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/src/CustomerUpdate.API"
RUN dotnet build "CustomerUpdate.API.csproj" -c Release -o /app/build

# Publish the application
FROM build AS publish
RUN dotnet publish "CustomerUpdate.API.csproj" -c Release -o /app/publish

# Final stage
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Create ODBC configuration for AS400
RUN echo "[AS400_ODBC]" > /etc/odbc.ini && \
    echo "Description=AS400 ODBC Connection" >> /etc/odbc.ini && \
    echo "Driver=IBM i Access ODBC Driver" >> /etc/odbc.ini && \
    echo "System=AS400-SYSTEM-NAME" >> /etc/odbc.ini && \
    echo "UserID=APIUSER" >> /etc/odbc.ini && \
    echo "Password=API_PASSWORD" >> /etc/odbc.ini && \
    echo "DefaultLibraries=CUSTLIB,CUSTDATA,CUSTLOG" >> /etc/odbc.ini && \
    echo "CommitMode=2" >> /etc/odbc.ini && \
    echo "ExtendedDynamic=1" >> /etc/odbc.ini

# Set environment variables
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:80

ENTRYPOINT ["dotnet", "CustomerUpdate.API.dll"] 