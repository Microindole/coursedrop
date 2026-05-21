Set-StrictMode -Version Latest

Push-Location "$PSScriptRoot/../apps/server"
try {
  ./mvnw spring-boot:run
} finally {
  Pop-Location
}

