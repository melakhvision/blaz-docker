FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY kapp.csproj .
RUN dotnet restore kapp.csproj
COPY . .
RUN dotnet build kapp.csproj -c Release -o /app/build

FROM build AS publish
RUN dotnet publish kapp.csproj -c Release -o /app/publish

FROM nginx:alpine AS final
COPY nginx.conf /etc/nginx/conf.d/configfile.template
ENV PORT 80
ENV HOST 0.0.0.0
RUN sh -c "envsubst '\$PORT'  < /etc/nginx/conf.d/configfile.template > /etc/nginx/conf.d/default.conf"
COPY --from=publish /app/publish/wwwroot /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]