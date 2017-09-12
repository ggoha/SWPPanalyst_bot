Rails.application.routes.draw do
  telegram_webhooks division: TelegramDivisionController,
                    parser: TelegramParserController,
                    default: TelegramViewController

                  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
