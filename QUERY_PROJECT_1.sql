-- Looking at some Data
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths as Death Percentage in Brazil
-- Shows likelihood of dying if you contract covid
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where location like 'brazil'
order by 1,2 desc

-- Looking at Total Cases vs Population
-- Infection Percentage
select location, date, total_cases, population, (total_cases/population)*100 as Infection_Percentage
from PortfolioProject..CovidDeaths
where location like 'brazil'
order by 1,2

-- Looking at countries with Highest Infection Rate compared to Population

select 
location, 
population/10 as population, 
MAX(total_cases)/10 as Highest_Infection_Count, 
MAX(total_cases/population)*100 as Percent_Population_Infected
from PortfolioProject..CovidDeaths
group by location, population
order by Percent_Population_Infected desc

-- Countries with the Highest Death Count per Population
select location,max(cast(total_deaths as bigint)) as totalDeathCount
from PortfolioProject..CovidDeaths
where location like 'bra%'
group by location
order by totalDeathCount desc

select new_vaccinations from PortfolioProject..CovidVaccinations

--Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) 
over (partition by dea.location
order by dea.date) as RollingVaccination
--, (RollingVaccination/population)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- USING CTE

with PopvsVac (continent, Location, Date, Population, new_vaccinations, RollingVaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) 
over (partition by dea.location
order by dea.date) as RollingVaccination
--, (RollingVaccination/population)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingVaccination/population)*100 from PopvsVac

--CREATING VIEW FOR IT
CREATE VIEW PercentPopVac as
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) 
over (partition by dea.location
order by dea.date) as RollingVaccination
--, (RollingVaccination/population)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3