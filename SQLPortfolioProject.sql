SELECT * 
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

SELECT * 
FROM PortfolioProject..CovidVaccinations
order by 3,4

---Data we'll most likely be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--- looking at the Total Cases vs the Total Deaths 
-- shows the likelihood of dying if one contacts covid in Nigeria

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location =  'Nigeria' and continent is not null
order by 1,2

-- Total Cases vs Population
-- shows the percentage of Nigeria's population that has gotten Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentpopulationInfected
FROM PortfolioProject..CovidDeaths
where location =  'Nigeria' and continent is not null
order by 1,2

-- countries with the highest infection rate compared to population

SELECT location, population, max(total_cases) as HighestInfectionCount,
max((total_cases/population)*100) as PercentpopulationInfected
FROM PortfolioProject..CovidDeaths
where continent is not null
--where location =  'Nigeria'
group by location, population
order by PercentpopulationInfected desc

-- country with the highest death count per population
SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location =  'Africa'
where continent is not null
group by location
order by TotalDeathCount desc

--continent with the highest death count per population
SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location =  'Africa'
where continent is not null
group by continent
order by TotalDeathCount desc

SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location =  'Africa'
where continent is null
group by location
order by TotalDeathCount desc

SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location =  'Africa'
--where continent is not null
group by location
order by TotalDeathCount desc


--GLOBAL NUMBERS
SELECT date, sum(new_cases), sum(cast(new_deaths as int)) 
--total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
--where location =  'Nigeria'
group by date
order by 1, 2

SELECT date, sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewdeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as NewDeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
--where location =  'Nigeria'
group by date
order by 1,2

SELECT sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewdeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as NewDeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
--where location =  'Nigeria'
--group by date
order by 1,2

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date


-- Looking at total population vs  vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
order by 2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with PopvsVac(continent, location, date, population,New_vaccinations, RollingPeopleVaccinated) 
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- TEMP TABLE

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinated numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--In order to add or remove something in the table add the drop statement

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinated numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select*, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

---Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
--order by 2,3

create view TotalDeathCount as
SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location =  'Africa'
where continent is not null
group by location
--order by TotalDeathCount desc