require 'rails_helper'

feature 'Admin legislation processes' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  context "Feature flag" do

    scenario 'Disabled with a feature flag' do
      Setting['feature.legislation'] = nil
      expect{ visit admin_legislation_processes_path }.to raise_exception(FeatureFlags::FeatureDisabled)
    end

  end

  context "Index" do

    scenario 'Displaying legislation processes' do
      process = create(:legislation_process)
      visit admin_legislation_processes_path(filter: 'all')

      expect(page).to have_content(process.title)
    end
  end

  context 'Create' do
    scenario 'Valid legislation process' do
      visit admin_root_path

      within('#side_menu') do
        click_link "Collaborative Legislation"
      end

      expect(page).to_not have_content 'An example legislation process'

      click_link "New process"

      fill_in 'legislation_process_title', with: 'An example legislation process'
      fill_in 'legislation_process_summary', with: 'Summary of the process'
      fill_in 'legislation_process_description', with: 'Describing the process'
      fill_in 'legislation_process_target', with: 'This thing affects people'
      fill_in 'legislation_process_how_to_participate', with: 'You can partipate in this thing by doing...'

      base_date = Date.current
      fill_in 'legislation_process[start_date]', with: base_date.strftime("%d/%m/%Y")
      fill_in 'legislation_process[end_date]', with: (base_date + 5.days).strftime("%d/%m/%Y")

      fill_in 'legislation_process[debate_start_date]', with: base_date.strftime("%d/%m/%Y")
      fill_in 'legislation_process[debate_end_date]', with: (base_date + 2.days).strftime("%d/%m/%Y")
      fill_in 'legislation_process[draft_publication_date]', with: (base_date + 3.days).strftime("%d/%m/%Y")
      fill_in 'legislation_process[allegations_start_date]', with: (base_date + 3.days).strftime("%d/%m/%Y")
      fill_in 'legislation_process[allegations_end_date]', with: (base_date + 5.days).strftime("%d/%m/%Y")
      fill_in 'legislation_process[final_publication_date]', with: (base_date + 7.days).strftime("%d/%m/%Y")

      click_button 'Create process'

      expect(page).to have_content 'An example legislation process'
      expect(page).to have_content 'Process created successfully'

      click_link 'Click to visit'

      expect(page).to have_content 'An example legislation process'
      expect(page).not_to have_content 'Summary of the process'
      expect(page).to have_content 'Describing the process'
      expect(page).to have_content 'This thing affects people'

      visit legislation_processes_path

      expect(page).to have_content 'An example legislation process'
      expect(page).to have_content 'Summary of the process'
      expect(page).not_to have_content 'Describing the process'
      expect(page).not_to have_content 'This thing affects people'
    end
  end

  context 'Update' do
    scenario 'Deactivate debate phase', js: true do
      process = create(:legislation_process,
                       title: 'An example legislation process',
                       summary: 'Summarizing the process',
                       description: 'Description of the process')
      visit admin_root_path

      within('#side_menu') do
        click_link "Collaborative Legislation"
      end

      click_link "An example legislation process"

      expect(page).to have_selector("h2", text: "An example legislation process")
      expect(find("#debate_phase_active")).to be_checked

      uncheck "debate_phase_active"
      fill_in 'legislation_process_summary', with: ''
      click_button "Save changes"

      expect(page).to have_content "Process updated successfully"
      expect(find("#debate_start_date").value).to be_blank
      expect(find("#debate_end_date").value).to be_blank

      visit legislation_processes_path
      expect(page).not_to have_content 'Summarizing the process'
      expect(page).to have_content 'Description of the process'
    end
  end
end
