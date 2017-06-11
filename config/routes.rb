Rails.application.routes.draw do
	root 'rooms#index'
	get '/find' => 'rooms#index'
end 
