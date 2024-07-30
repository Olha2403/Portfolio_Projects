Select *
From Portfolio_Projects..Covid_Deaths
order by 3,4

Select *
From Portfolio_Projects..Covid_Deaths
where Continent is not NULL
order by 3,4

--Select *
--From Portfolio_Projects..Covid_Vaccinations
--order by 3,4

--Select Datathat we are going to be using

Select location, date, total_cases, total_deaths, population
From Portfolio_Projects..Covid_Deaths
order by 1,2

--loking at Total Cases vs Total Deaths
--Show likelihood of dying if you contract covid in your  country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deth_precentage
From Portfolio_Projects..Covid_Deaths
Where location like '%krai%'
order by 1,2


--loking total cases vs population
--show what percentage of population got Covid  
Select location, date, total_cases, population, (total_cases/population)*100 as PrecentPopulationInfected
From Portfolio_Projects..Covid_Deaths
Where location like '%krai%'
order by 1,2


--looking at countries with highest infection rate compared to population

Select location,  population,MAX(total_cases) as highestInfectionCount , MAX((total_cases/population))*100 as PrecentPopulationInfected
From Portfolio_Projects..Covid_Deaths
Group by location, population
order by PrecentPopulationInfected desc

-- Showing countries  with highest death Count per population

Select location, MAX(cast(total_deaths as int)) as totalDeathCount 
From Portfolio_Projects..Covid_Deaths
where Continent is not NULL
Group by location
order by totalDeathCount desc

--let's break things down by continent

Select Continent, MAX(cast(total_deaths as int)) as totalDeathCount 
From Portfolio_Projects..Covid_Deaths
where Continent is not NULL
Group by Continent
order by totalDeathCount desc

--GLOBAL NUMBER

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_death, SUM(new_cases )/ SUM(new_deaths) as DeathPercentage
From Portfolio_Projects..Covid_Deaths
where Continent is not null and new_cases !=0 and new_deaths !=0
order by 1,2


-- Looking total population vs Vaccination

Select dea.Continent, dea.location,dea.date ,dea.population, vac.new_vaccinations
       , SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date )
	       as RollingPeopleVaccinated
	   --,(RollingPeopleVaccinated / population) *100
From Portfolio_Projects..Covid_Deaths dea
Join Portfolio_Projects..Covid_Vaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--CTE
With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.Continent, dea.location,dea.date ,dea.population, vac.new_vaccinations
       , SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date )
	       as RollingPeopleVaccinated
	   --,(RollingPeopleVaccinated / population) *100
From Portfolio_Projects..Covid_Deaths dea
Join Portfolio_Projects..Covid_Vaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null 
)

Select * , (RollingPeopleVaccinated / population) *100
From PopvsVac

--TEMP TABLE


DROP Table if exists #PrecentPopulationVaccinated
Create Table #PrecentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PrecentPopulationVaccinated
Select dea.Continent, dea.location,dea.date ,dea.population, vac.new_vaccinations
       , SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date )
	       as RollingPeopleVaccinated
From Portfolio_Projects..Covid_Deaths dea
Join Portfolio_Projects..Covid_Vaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null

Select * , (RollingPeopleVaccinated / population) *100
From #PrecentPopulationVaccinated


Create View PrecentPopulationVaccinated as
Select dea.Continent, dea.location,dea.date ,dea.population, vac.new_vaccinations
       , SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date )
	       as RollingPeopleVaccinated
From Portfolio_Projects..Covid_Deaths dea
Join Portfolio_Projects..Covid_Vaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null

Select * 
From PrecentPopulationVaccinated
