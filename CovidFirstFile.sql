select *
From PortfolioProject..CovidDeaths$

-- Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths$
order by 1,2

-- Total Cases vs Total deaths. Percentage of deaths per cases in Guatemala vs Russia.
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths$
Where location like '%Russia%' and
	date = '2020-08-28' or
	location like '%Guatemala%' and 
	date = '2020-08-28'
order by 1,2

-- Looking at total cases vs Population. Percentage of population that got covid Guatemala vs Russia
Select location, date, population, total_cases, (total_cases/population)*100 as cases_Percentage 
From PortfolioProject..CovidDeaths$
Where location like '%Russia%' and
	date = '2020-08-28' or
	location like '%Guatemala%' and 
	date = '2020-08-28'
order by 1,2

-- Countries with highest infection rate compared to population

Select location, population, MAX(cast(total_cases as int)) as HighestInfectionCount, MAX((total_cases/population))*100 as cases_Percentage
From PortfolioProject..CovidDeaths$
where continent is not null 
Group by location, population
order by HighestInfectionCount desc

-- Countries with highest deaths per population 

Select location, population, MAX(cast(total_deaths as int)) as HighestDeathsCount, MAX((total_deaths/population))*100 as deaths_Percentage
From PortfolioProject..CovidDeaths$
where continent is not null 
Group by location, population
order by HighestDeathsCount desc

-- deaths by continent

Select continent, MAX(cast(total_deaths as int)) as HighestDeathsCount
From PortfolioProject..CovidDeaths$
where continent is not null 
Group by continent 
order by HighestDeathsCount desc

--total cases worldwide to the 28th of August 2021
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage 
from PortfolioProject..CovidDeaths$
where continent is not null 

-- vaccinations totals by date in each country.
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) OVER (Partition by d.location order by d.location, d.date) as added_vaccinations
from PortfolioProject..CovidDeaths$ d
Join PortfolioProject..CovidVaccinations$ v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null and 
v.new_vaccinations is not null 
order by 2,3

-- percentage of people vaccinated in each country over time (if each person gets 1 shot only)

with vacc (continent, location, date, population, new_vaccinations, vaccinations_given)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(int,v.new_vaccinations)) OVER (Partition by d.location order by d.location, d.date) as vaccinations_given
from PortfolioProject..CovidDeaths$ d
Join PortfolioProject..CovidVaccinations$ v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null  
)
select *, vaccinations_given/population as percentage_population_vaccinated
from vacc
where location like '%Guatemala%'

create view PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) OVER (Partition by d.location order by d.location, d.date) as added_vaccinations
from PortfolioProject..CovidDeaths$ d
Join PortfolioProject..CovidVaccinations$ v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null and 
v.new_vaccinations is not null 
--der by 2,3


--convert(float,extreme_poverty) 

