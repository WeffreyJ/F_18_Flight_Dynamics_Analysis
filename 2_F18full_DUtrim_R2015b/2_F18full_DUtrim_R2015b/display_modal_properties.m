function display_modal_properties(name, modal_properties)
    disp(['Modal Properties for ', name, ':'])
    for i = 1:numel(modal_properties)
        fprintf('Eigenvalue %d:\n', i);
        fprintf('  Damping Ratio: %.4f\n', modal_properties(i).DampingRatio);
        fprintf('  Natural Frequency: %.4f rad/s\n', modal_properties(i).NaturalFrequency);
        fprintf('  Frequency: %.4f Hz\n', modal_properties(i).Frequency);
        fprintf('  Period: %.4f s\n', modal_properties(i).Period);
    end
end
