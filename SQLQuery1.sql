Select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select * from PortfolioProject..CovidVaccinations
--order by 3,4

-- Select data to be used

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths
-- Likelihood of dying if covid positive in USA

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Total Cases vs Population
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopInfec
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Countries with highest infection rate compared to population
Select location, population, max(total_cases) as HighestInfecCount, max((total_cases/population))*100 as PercentPopInfected
from PortfolioProject..CovidDeaths
group by location, population
order by PercentPopInfected desc

-- Highest Death Count per Population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc



-- more correct(why??)
--Select location, max(cast(total_deaths as int)) as TotalDeathCount
--from PortfolioProject..CovidDeaths
--where continent is null
--group by location
--order by TotalDeathCount desc

--Showing continents with highest death count per pop

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers each day

--Wrong
--Select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
--from PortfolioProject..CovidDeaths
--where continent is not null
--group by date
--order by 1,2

--Right
Select date, sum(new_cases)
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

Select date, sum(new_cases), sum(cast(new_deaths as int))
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

Select date, sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercent
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

Select sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercent
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2




--Join Covid Death and Vaccination tables

Select * 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


-- Total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- convert instead of cast
-- bigint instead of int
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as totalPplVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Wrong as we can not use a column just created

--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as totalPplVaccinated,
--(totalPplVaccinated/population)*100
--from PortfolioProject..CovidDeaths dea
--Join PortfolioProject..CovidVaccinations vac
--	on dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


--CTE
--order by clause can not be in here(why??)

with popvsVac (Continent, location, date, population, new_vaccinations, totalPplVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as totalPplVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (totalPplVaccinated/population)*100 from popvsVac


--Temp Table
-- Drop table if exists #PercentPopVaccinated- helps if alterations being made, when run multiple times
create table #PercentPopVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
totalPplVaccinated numeric
)

insert into #PercentPopVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as totalPplVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (totalPplVaccinated/population)*100 from #PercentPopVaccinated


-- Creating view to store data for later visualizations
use PortfolioProject
GO
Create View PercentPopVaccinated 
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as totalPplVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Go
--select * from PercentPopVaccinated
--Drop view PercentPopVaccinated
