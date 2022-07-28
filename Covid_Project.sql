--Select *
--from [Portfolio project]..CovidDeaths$
--order by 3,4

--Select *
--from [Portfolio project]..CovidVaccinations$

Select location, date,total_cases,new_cases, total_deaths, population
from [Portfolio project]..CovidDeaths$
where continent is not null
order by 1,2


--Looking at Total cases vs Total Deaths
--Effect of reducing covid in tptal deaths in a country

Select location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from [Portfolio project]..CovidDeaths$
where location like '%states%'
order by 2

--Looking at Total cases vs population
--Shows percentage of population got Covid

Select location, date,total_cases, population, (total_cases/population)*100 as case_percentage
from [Portfolio project]..CovidDeaths$
where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate with respect to population

Select location,population,max(total_cases) as Highest_Infection_count, max((total_cases/population))*100 as Percent_population_infected
from [Portfolio project]..CovidDeaths$
where continent is not null
group by location,population
order by Percent_population_infected desc

--Showing countries with highest death count with respect to population

Select location, max(cast(total_deaths as int)) as Total_death_count
from [Portfolio project]..CovidDeaths$
where continent is not null
group by location
order by Total_death_count desc

--Analysing by continent
--Continents with highest death counts
Select continent, max(cast(total_deaths as int)) as Total_death_count
from [Portfolio project]..CovidDeaths$
where continent is not null
group by continent
order by Total_death_count desc

--Global numbers
Select date, SUM(new_cases) as New_cases, sum(cast(new_deaths as int)) as New_deaths
from [Portfolio project]..CovidDeaths$
where continent is not null
group by date
order by 1,2

--Total numbers of new cases and deaths
Select SUM(new_cases) as New_cases, sum(cast(new_deaths as int)) as New_deaths
from [Portfolio project]..CovidDeaths$
where continent is not null
--group by date
order by 1,2

--Joining Vaccinations Table
Select *
from [Portfolio project]..CovidDeaths$ d
join [Portfolio project]..CovidVaccinations$ v
on d.location=v.location
and d.date=v.date

--Looking at total population vs Vaccinations
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (Partition by d.location order by d.location, d.date)
as Rollingpeoplevaccinated
from [Portfolio project]..CovidDeaths$ d
join [Portfolio project]..CovidVaccinations$ v
on d.location=v.location
and d.date=v.date
where d.continent is not null
order by 2,3

--Use CTE
With Popvsvac (Continent, Location,date, Population, new_vaccinations, Rollingpeoplevaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (Partition by d.location order by d.location, d.date)
as Rollingpeoplevaccinated
from [Portfolio project]..CovidDeaths$ d
join [Portfolio project]..CovidVaccinations$ v
on d.location=v.location
and d.date=v.date
where d.continent is not null
--order by 2,3
)
Select *, ( Rollingpeoplevaccinated/Population)*100
from Popvsvac

--Temp table
Drop Table if exists #PercentpopVaccinated
Create Table #PercentpopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)


Insert into #PercentpopVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (Partition by d.location order by d.location, d.date)
as Rollingpeoplevaccinated
from [Portfolio project]..CovidDeaths$ d
join [Portfolio project]..CovidVaccinations$ v
on d.location=v.location
and d.date=v.date
where d.continent is not null
--order by 2,3

Select *, ( Rollingpeoplevaccinated/Population)*100
from #PercentpopVaccinated

--Creating view to store data for later visuals
Create View PercentpopVaccinated as 
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (Partition by d.location order by d.location, d.date)
as Rollingpeoplevaccinated
from [Portfolio project]..CovidDeaths$ d
join [Portfolio project]..CovidVaccinations$ v
on d.location=v.location
and d.date=v.date
where d.continent is not null
--order by 2,3

Select * from PercentpopVaccinated









