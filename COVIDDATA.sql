-- Select data int the CovidDeaths table

select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
order by 1,2

-- Total Case vs Total Deaths
-- Shows likelyhood of contracting the virus is Rwanda

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT)/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
where location like '%rwanda%'
ORDER BY 1, 2


-- Total Cases vs Population
-- Shows what percentage of the population that contracted the virus

SELECT location, date, total_cases, population, (CAST(total_cases AS FLOAT)/population)*100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths$
where location like '%rwanda%'
ORDER BY 1, 2

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(CAST(total_cases AS FLOAT)/population)*100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population
ORDER BY InfectionPercentage desc

-- Looking at countries with highest death rate compared to population 

SELECT location,  MAX(total_deaths) as HighestDeathCount
FROM PortfolioProject..CovidDeaths$
where continent is not null
GROUP BY location
ORDER BY HighestDeathCount desc

-- Looking at continents with highest death rate compared to population 

SELECT continent,  MAX(total_deaths) as HighestDeathCount
FROM PortfolioProject..CovidDeaths$
where continent is not null
GROUP BY continent
ORDER BY HighestDeathCount desc

-- Global numbers 

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
CASE WHEN SUM(new_cases) = 0 THEN 0 ELSE (CAST(SUM(new_deaths) AS FLOAT) / SUM(new_cases))*100 END AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as VaccinatedPeopleCount
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
AND vac.new_vaccinations is not null
order by 1, 2, 3


-- USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations,VaccinatedPeopleCount)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as VaccinatedPeopleCount
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
AND vac.new_vaccinations is not null
)
select *,(VaccinatedPeopleCount/population)*100 as PercentPeopleVaccinated
from PopvsVac


-- Create View to store data for later visualizations

Create View PercentPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as VaccinatedPeopleCount
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
AND vac.new_vaccinations is not null


-- Query the created  view 
Select * from PercentPeopleVaccinated
