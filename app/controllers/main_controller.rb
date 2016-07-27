class MainController < ApplicationController
	# action for home page
	def home
		@room = ""
	end

	# receives post request
	def search
		response = HTTParty.get('https://api.uwaterloo.ca/v2/buildings/MC/2038/courses.json?
		key=3b21abe0bcae9daa1bfdae8baee017db')
		@room = response.body
		render 'home'
	end
end
